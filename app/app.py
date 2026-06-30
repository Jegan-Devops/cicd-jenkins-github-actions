from flask import Flask, jsonify

app = Flask(__name__)


@app.route("/")
def home():
    return jsonify(message="CI/CD demo app is running", status="healthy")


@app.route("/health")
def health():
    # A dedicated health endpoint is what ECS/ALB target groups poll —
    # separating it from "/" means business logic changes never break health checks.
    return jsonify(status="ok"), 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
