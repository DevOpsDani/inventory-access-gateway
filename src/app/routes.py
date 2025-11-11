from flask import Flask, request, jsonify
import requests


def register_routes(app: Flask):
    @app.route("/health")
    def health():
        return jsonify({"status": "ok"})
    
    @app.route("/ready")    
    def ready():
        if not app.config.get("APPSYNC_API_URL"):
            return jsonify({"status": "not ready"}), 503
        return jsonify({"status": "ready"})

    @app.route("/data", methods=["POST"])
    def receive_data():
        data = request.get_json()
        if not data:
            return jsonify({"error": "Missing JSON body"}), 400

        user = getattr(request, "user", {}).get("username", "unknown user")
        return jsonify({
            "message": f"Data received successfully from {user}",
            "received": data
        })


    @app.route("/query", methods=["POST"])
    def receive_data_per_tenant():
        data = request.get_json()
        if not data:
            return jsonify({"error": "Missing JSON body"}), 400

        # Extract user info and groups
        payload = getattr(request, "user", {})
        username = payload.get("username", "unknown user")
        groups = payload.get("cognito:groups", [])
        auth_header = request.headers.get("Authorization", "")

        # Check if user is in group
        if not groups:
            return jsonify({"error": "User does not belong to any group"}), 403

        # Take the users first group as their tenant
        tenant = groups[0]
        jwt_token = auth_header.split(" ")[1]
        graphql_query = data["query"]

        try:
            response = requests.post(
                app.config["APPSYNC_API_URL"],
                headers={
                    "Authorization": jwt_token,
                    "Content-Type": "application/json"
                },
                json={
                    "query": graphql_query
                }
            )

            if response.status_code != 200:
                return jsonify({
                    "error": f"AppSync returned {response.status_code}",
                    "details": response.text
                }), response.status_code

            return jsonify({
                "message": f"Query executed for tenant {tenant} by {username}",
                "appsync_response": response.json()
            })

        except Exception as e:
            return jsonify({"error": f"Failed to query AppSync: {str(e)}"}), 500