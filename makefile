builddocker:
	docker build -t kokoro .
dockerbash:
	docker run -it     --gpus all  --shm-size=16GB  kokoro:latest bash
docker:
	docker run -it     --gpus all  --shm-size=16GB  kokoro:latest
