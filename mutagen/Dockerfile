FROM alpine:3.12

COPY scripts /usr/share/mutagen-scripts
RUN chmod a+x /usr/share/mutagen-scripts/*

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod a+x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["tail", "-f", "/dev/null"]
