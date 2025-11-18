FROM vuiiscci/slant:deep_brain_seg_v1_0_0
COPY slant/start.sh /opt/start.sh
COPY common/memory.sh /opt/memory.sh
RUN chmod +x /opt/start.sh /opt/memory.sh
RUN mkdir -p /CUSTOM_INPUTS
RUN mkdir -p /CUSTOM_OUTPUTS
CMD ["/bin/bash", "/opt/start.sh"]
