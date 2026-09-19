# Official repo has no Docker. This image follows their README on Ubuntu 20.04.
# High-level planner only (MeshCat). ROS2 Foxy / full MuJoCo stack is not included.
FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    INHAND_HOME=/workspace/high_level \
    QSIM_HOME=/workspace/high_level/quasistatic_simulator \
    PATH=/opt/openrobots/bin:/opt/drake/bin:$PATH \
    LD_LIBRARY_PATH=/opt/openrobots/lib:/opt/drake/lib \
    PYTHONPATH=/opt/openrobots/lib/python3.8/site-packages:/workspace/high_level/planning_through_contact:/workspace/high_level/planner:/workspace/high_level/quasistatic_simulator:/workspace/high_level/quasistatic_simulator/quasistatic_simulator_cpp/build/bindings

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates curl wget git gnupg2 lsb-release \
        python3.8 python3.8-dev python3.8-venv python3-pip python3.8-distutils \
        build-essential cmake pkg-config \
        libeigen3-dev libboost-all-dev \
    && ln -sf /usr/bin/python3.8 /usr/local/bin/python \
    && ln -sf /usr/bin/python3.8 /usr/local/bin/python3 \
    && rm -rf /var/lib/apt/lists/*

# Drake 1.22 C++ runtime (must be the Focal package)
RUN wget -q https://github.com/RobotLocomotion/drake/releases/download/v1.22.0/drake-dev_1.22.0-1_amd64-focal.deb \
    && apt-get update \
    && apt-get install -y --no-install-recommends ./drake-dev_1.22.0-1_amd64-focal.deb \
    && rm -f drake-dev_1.22.0-1_amd64-focal.deb \
    && rm -rf /var/lib/apt/lists/*

# Pinocchio + Crocoddyl via robotpkg. Latest candidates conflict
# (py38-pinocchio 3.4.0 wants casadi 3.6.7, repo default is 3.7.2r1).
ARG http_proxy
ARG https_proxy
RUN echo "deb [arch=amd64] http://robotpkg.openrobots.org/packages/debian/pub focal robotpkg" \
        > /etc/apt/sources.list.d/robotpkg.list \
    && curl -fsSL http://robotpkg.openrobots.org/packages/debian/robotpkg.key | apt-key add - \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        robotpkg-casadi=3.6.7 \
        robotpkg-py38-casadi=3.6.7 \
        robotpkg-pinocchio=3.4.0 \
        robotpkg-py38-pinocchio=3.4.0 \
        robotpkg-py38-example-robot-data=4.2.0 \
        robotpkg-py38-crocoddyl=2.1.0r1 \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt /tmp/requirements.txt
RUN python3.8 -m pip install --no-cache-dir -U pip \
    && python3.8 -m pip install --no-cache-dir -r /tmp/requirements.txt \
    && python3.8 -m pip install --no-cache-dir manipulation --no-dependencies \
    && python3.8 -m pip install --no-cache-dir --extra-index-url https://drake-packages.csail.mit.edu/whl/nightly/ 'drake==1.22.0' \
    && python3.8 -m pip install --no-cache-dir 'numpy==1.24.4' 'scipy==1.10.1'

WORKDIR /workspace
CMD ["bash"]
