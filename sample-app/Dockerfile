FROM python:3.8.10-slim

ENV VIRTUAL_ENV=/venv
RUN python -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

COPY . .

RUN pip install --upgrade pip && \
    pip install -r requirements.txt

CMD ["python", "app.py"]
