FROM masidocker/spiders:MaCRUISE_v3_1_0
COPY macruise/start.sh /opt/start.sh
COPY common/memory.sh /opt/memory.sh
RUN chmod +x /opt/start.sh /opt/memory.sh
RUN mkdir -p /CUSTOM_INPUTS
RUN mkdir -p /CUSTOM_OUTPUTS
CMD ["/bin/bash", "/opt/start.sh"]
