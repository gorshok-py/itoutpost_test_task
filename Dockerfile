FROM alpine:3.14
ENV GIT_REPO_DIR=/git
RUN apk add --no-cache git bash && mkdir /script && mkdir $GIT_REPO_DIR && mkdir /logs
COPY simple-script.sh /script/
RUN chmod +x /script/simple-script.sh
ENTRYPOINT ["/script/simple-script.sh"]
