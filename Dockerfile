FROM ghcr.io/astral-sh/uv:python3.12-trixie

ARG UNAME=cph
ARG USER_ID=1000
ARG GROUP_ID=1000

RUN set -eux && apt-get -y update && apt-get install -y vim sudo

# 设置sudo组不需要密码就可以进行sudo
RUN sed -i 's/%sudo\s\+ALL=(ALL:ALL)\s\+ALL/%sudo ALL=(ALL:ALL) NOPASSWD :ALL/' /etc/sudoers

# -U 创建与用户同名的组
# -G 新账户的附加组列表
RUN set -eux && useradd -m -s /bin/bash -U -G sudo -u ${USER_ID} ${UNAME}


COPY --chown=cph:cph kokoro/ /app/kokoro
COPY --chown=cph:cph .python-version kokoro.js  pyproject.toml  uv.lock /app/

WORKDIR /app
ENV UV_LINK_MODE=copy
RUN --mount=type=cache,target=/home/cph/.cache/uv set -eux && touch LICENSE && uv sync

RUN cat > ~/.gitconfig << EOF
[url "https://ghfast.top/https://github.com/"]
	insteadof = https://github.com/
[safe]
	directory = *
EOF

ADD https://raw.githubusercontent.com/chang-ph/kokoro/refs/heads/main/example.py /app/example.py

ENV HF_ENDPOINT=https://hf-mirror.com
RUN uv run -m kokoro -t "测试" --voice "zm_100" -o "{0:008d}.wav"

ENTRYPOINT ["uv", "run", "-m", "kokoro"]
