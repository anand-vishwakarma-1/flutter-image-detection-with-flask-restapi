# flutter image detection app with flask restapi


<img src="readme_images/grid.jpg" width="20%">  <img src="readme_images/predicted.jpg" align="left" width="20%">

This app is made for testing deep learning object detection models hosted using flask server.
Any object detection model is compatible with the app, the only required is changing the predict.py with your model's predict function

At app start it requires to connect to a server, uploading and predicting before connection is not possibly, app will popup an error for it and ask for connecting to the server.

<img src="readme_images/server.jpg" width="20%">

App also has a filter menu to sort and filter images based on prediction count or time uploaded/predicted.

<img src="readme_images/filter.jpg" width="20%">
