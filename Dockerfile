FROM runtimeverificationinc/kontrol:ubuntu-jammy-1.0.0

COPY . /home/user/workshop

USER root
RUN chown -R user:user /home/user
USER user

WORKDIR /home/user/workshop

RUN kontrol build
RUN kontrol prove -j6 || true

ENTRYPOINT ["/bin/bash"]