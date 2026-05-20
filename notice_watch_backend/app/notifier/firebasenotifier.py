from app.db.models import DeviceToken
from firebase_admin import messaging


def send_notification(db, title: str, body: str | None = None):

    tokens = db.query(DeviceToken).all()

    if not tokens:
        print("No devices registered")
        return

    for device in tokens:
        try:
            message = messaging.Message(
                data={
                    "title": "New Notice",
                    "body": title or "",
                },
                android=messaging.AndroidConfig(
                    priority="high",
                ),
                token=device.token,
            )

            response = messaging.send(message)

            print("Notification sent:", response)

        except Exception as e:
            print("FCM Error:", e)


# send_notification(
#         token="Test_Token",
#         title="Hello",
#         body="Firebase working"
#     )
