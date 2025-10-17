FROM masidocker/public:deep_brain_seg_v1_1_0
COPY common/start.sh /opt/start.sh
COPY common/mem.sh /opt/mem.sh
RUN chmod +x /opt/start.sh /opt/mem.sh
CMD ["/bin/bash", "/opt/start.sh"]
