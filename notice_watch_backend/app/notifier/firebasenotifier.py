from app.firebase.firebase import app
from firebase_admin import messaging

def send_notification(token:str, title:str, body:str):
    message = messaging.Message(
        notification=messaging.Notification(
            title=title,
            body=body,
        ),
        token=token
    )

    response = messaging.send(message)

    print("Notification sent:", response)




send_notification(
        token="Test_Token",
        title="Hello",
        body="Firebase working"
    )