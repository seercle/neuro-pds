FROM vuiiscci/slant:deep_brain_seg_v1_0_0
COPY common/start.sh /opt/start.sh
COPY common/mem.sh /opt/mem.sh
RUN chmod +x /opt/start.sh /opt/mem.sh
RUN mkdir -p /CUSTOM_INPUTS
RUN mkdir -p /CUSTOM_OUTPUTS
CMD ["/bin/bash", "/opt/start.sh"]
