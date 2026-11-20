from flask import Flask, jsonify, render_template

app = Flask(__name__)

devices = [
            {"name": "Core-Router-01", "status": "online"},
            {"name": "Access-Switch-01", "status": "online"},
            {"name": "Branch-Router-01", "status": "offline"}
]

@app.route("/")
def home():
    return render_template("index.html", devices=devices)

@app.route("/api/devices")
def get_devices():
        return jsonify(
                    {
                        "application": "Network Operations Dashboard",
                        "devices": devices
                    }           
        )

@app.route("/health")
def health():
        return jsonify({"status": "ok"})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080, debug=True)