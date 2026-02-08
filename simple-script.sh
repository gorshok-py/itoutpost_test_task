#!/usr/bin/env bash


file_input=$1 #TODO add logic to check if file exist
file_output='nginx.csv'



regex_for_ip='^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'
regex_for_status_code='^[1-5][0-9]{2}$'
regex_for_nums='^[0-9]+(\.[0-9]+)?$'
regex_for_api='[a-zA-Z]'


git_logic() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    # Check env in dockerfile and .env
    if [ -z "$GIT_REPO_DIR" ] || [ -z "$GIT_REPO_URL" ] || [ -z "$GIT_TOKEN" ] || [ -z "$GIT_USER" ]; then
        echo "Error: Missing required environment variables"
        echo "Please set: GIT_REPO_DIR, GIT_REPO_URL, GIT_TOKEN, GIT_USER"
        exit 1
    fi

    cd "$GIT_REPO_DIR" || exit 1

    if [ ! -d ".git" ]; then
        echo "Initializing git repository..."
        git init
        git config user.name "$GIT_USER"
        git config user.email "${GIT_USER}@mail.local"
        git branch -M main
        git remote add origin https://$GIT_USER:${GIT_TOKEN}@${GIT_REPO_URL}
    fi

    if [ ! -f "$file_output" ]; then
        echo "Error: File $file_output not found in $GIT_REPO_DIR, you must convert file first"
        exit 1
    fi
    git add "$file_output"
    git commit -m "$timestamp | $commit_message"

    echo "Pushing to repository..."
    git push -f origin main #I don't need old commit data.

    if [ $? -eq 0 ]; then
        echo "Successfully pushed $file_output to repository"
    else
        echo "Error: Failed to push to repository"
        exit 1
    fi
}


csv_converter() {

awk '
BEGIN { OFS = "," }

{
        remote_addr = $1;
        ident_id = $2;
        username = $3;
        timestamp = $4 " " $5;
        api_end = $6 " " $7 " " $8;
        status_code = $9;
        body_size = $10;
        refer_page = $11;
        ua = $12 " " $13 " " $14 " " $15 " " $16 " " $17 " " $18 " " $19 " " $20 " " $21 " " $22 " " $23 " " $24;
        request_length = $25;
        request_time = $26;
        upstream_name = $27;
        upstream_addr = $28;
        fact_upstream_addr = $29;
        resp_size = $30;
        upstream_resp_time = $31;
        upstream_resp = $32;
        trace_id = $33;
        print remote_addr, ident_id, username, timestamp, api_end, status_code, body_size, refer_page, ua, request_length, request_time, upstream_name, upstream_addr, fact_upstream_addr, resp_size, upstream_resp_time, upstream_resp, trace_id;
}'
                   }

case "$2" in
  --help)
    echo "Usage: $0 <logfile> [option]"
    echo "Options:"
    echo "  --plain                        convert to csv"
    echo "  --get-endpoints                list unique endpoints"
    echo "  --get-ip                       list unique ips"
    echo "  --store                        push csv file to git"
    echo "  --count by-request             count requests per IP"
    echo "  --count by-body-size           sum body size per IP"
    echo "  --filter by-ip <ip>            filter by IP"
    echo "  --filter by-status-code <code> filter by status"
    echo "  --filter by-response-time <t>  filter by response time"
    echo "  --filter by-endpoint <name>    filter by endpoint"
    echo "  --sort by-request-time         sort by request time"
    echo "  --sort by-status-code          sort by status code"
    echo "  --sort by-body-bytes           sort by body bytes"
    echo "  --sort by-ip                   sort by IP address"
    ;;
  --get-env)
    echo "$GIT_REPO_DIR"
    echo "$GIT_REPO_URL"
    echo "$GIT_TOKEN"
    echo "$GIT_USER"

    ;;
  --plain)
   cat $file_input | csv_converter > $GIT_REPO_DIR/$file_output
    ;;

 --get-ip)
    cat $file_input|awk '{print $1}'|sort -u
    ;;

  --get-endpoints)
    awk -F'[/?]' '{print $5}' $file_input|sort -u
    ;;

  --store)
    if [ -f "$GIT_REPO_DIR/$file_output" ]; then
       git_logic "$script_params"
    else
       echo "File $file_output doesn't exist, generate file first"
    fi
    ;;

  --count)
    case "$3" in
         by-request)
            awk '{count[$1]++} END {for (ip in count) print ip " total number of requests " count[ip]}' $file_input
          ;;

         by-body-size)
            awk '{sum[$1] += $10} END {for (ip in sum) print ip " total body size " sum[ip] / 1024 " Kilobytes"}' $file_input
          ;;

         *)
         echo "Error: No option specified"
         exit 1
         ;;

     esac
     ;;

  --filter)
    case "$3" in
          by-ip)
             if [[ $4 =~ $regex_for_ip ]]; then
                grep -e "\b$4\b" $file_input | csv_converter > $GIT_REPO_DIR/$file_output
             else
                echo "Error: ip address should be valid"
             fi
          ;;

          by-status-code)
             if [[ $4 =~ $regex_for_status_code ]]; then
                grep -e "\b$4\b" $file_input | csv_converter > $GIT_REPO_DIR/$file_output
             else
                echo "Error: status code should be valid"
             fi
          ;;

          by-response-time)
             if [[ $4 =~ $regex_for_nums ]]; then
                awk -v time="$4" '$26 == time' $file_input | csv_converter > $GIT_REPO_DIR/$file_output
             else
               echo "Error: value should be numerical"
             fi
          ;;

          by-endpoint)
             if [[ $4 =~ $regex_for_api ]]; then
                grep -e "\b$4\b" $file_input | csv_converter > $GIT_REPO_DIR/$file_output
             else
               echo "Error: value should contain endpoint"
             fi
          ;;

          *)
              echo "Error: No option specified"
              exit 1
          ;;

     esac
     ;;

  --sort)
    case "$3" in
          by-request-time)
             sort -k26,26n $file_input | csv_converter > $GIT_REPO_DIR/$file_output
          ;;

          by-status-code)
             sort -k9,9n $file_input | csv_converter > $GIT_REPO_DIR/$file_output
          ;;

          by-body-bytes)
             sort -k10,10n $file_input | csv_converter > $GIT_REPO_DIR/$file_output
          ;;

          by-ip)
             sort -t . -k 1,1n -k 2,2n -k 3,3n -k 4,4n $file_input | csv_converter > $GIT_REPO_DIR/$file_output
          ;;

          by-body-size)
             sort -k10,10n $file_input | csv_converter > $GIT_REPO_DIR/$file_output
          ;;

          *)
              echo "Error: No option specified"
              exit 1
          ;;
     esac
     ;;

  *)
    echo "Error: No option or logfile specified"
    echo "Usage: $0 <logfile> [option]"
    exit 1
    ;;

esac
