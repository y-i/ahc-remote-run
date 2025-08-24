FROM rust:1-bullseye AS builder

WORKDIR /App

RUN apt-get update && apt-get install -y unzip

ARG ZIP_URL=https://img.atcoder.jp/ahc051/jdd9gfQC.zip

# ダウンロード
ADD ${ZIP_URL} /App
RUN unzip ./*.zip
WORKDIR /App/tools

RUN cargo build --release --bin vis && strip /App/tools/target/release/vis -o /vis

ARG TIMES=1000

# 入力ファイル
RUN seq 0 $((TIMES - 1)) > seeds.txt
RUN cargo run --release --bin gen seeds.txt

FROM gcr.io/google.com/cloudsdktool/google-cloud-cli:stable

RUN mkdir -p /App/out
WORKDIR /App

COPY --from=builder /vis /App/
COPY --from=builder /App/tools/in/ /App/in/

# tmp
# COPY a.out /App/a.out

COPY ./task-noninteractive.sh /App/task.sh

RUN chmod +x /App/task.sh

CMD ["/App/task.sh"]
