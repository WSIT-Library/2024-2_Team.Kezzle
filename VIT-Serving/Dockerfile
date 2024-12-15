FROM public.ecr.aws/lambda/python:3.11

COPY requirements.txt ./
RUN python3 -m pip install -r requirements.txt

COPY app/main.py ./

# TODO: 나중에 학습한 모델로 교체하기
COPY model/vit.py ./
RUN python3 vit.py

CMD ["main.lambda_handler"]