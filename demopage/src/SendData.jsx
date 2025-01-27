import { useState, useEffect, useRef } from 'react';
import axios from 'axios';

const WebcamCapture = () => {
  const [responseMessage, setResponseMessage] = useState('');
  const [emotion, setEmotion] = useState('no-emotions');
  const [capturedImage, setCapturedImage] = useState(null); // State to store captured image URL
  const [isCapturing, setIsCapturing] = useState(false); // Track if the webcam is actively capturing
  const canvasRef = useRef(null);
  const intervalRef = useRef(null);
  const streamRef = useRef(null);

  // Start webcam without displaying video
  const startWebcam = async () => {
    try {
      const stream = await navigator.mediaDevices.getUserMedia({
        video: true,
      });
      streamRef.current = stream; // Store the stream for later use
      console.log('Webcam started');
    } catch (error) {
      console.error("Error accessing webcam:", error);
      setResponseMessage("Failed to access webcam");
    }
  };

  // Stop webcam and clear the interval
  const stopWebcam = () => {
    if (streamRef.current) {
      const tracks = streamRef.current.getTracks();
      tracks.forEach((track) => track.stop());
      streamRef.current = null;
    }
    if (intervalRef.current) {
      clearInterval(intervalRef.current); // Stop capturing
    }
    setIsCapturing(false); // Update state to indicate capturing is stopped
    setCapturedImage(null); // Clear captured image when stopping
    console.log('Webcam stopped and capturing process killed');
  };

  // Capture and send image to backend
  const captureAndSendImage = () => {
    const canvas = canvasRef.current;
    const context = canvas.getContext('2d');

    // Get video frame from webcam stream
    if (streamRef.current) {
      const videoTrack = streamRef.current.getVideoTracks()[0];
      const imageCapture = new ImageCapture(videoTrack);

      imageCapture
        .grabFrame()
        .then((imageBitmap) => {
          // Dynamically adjust the canvas size to match the video resolution
          const width = imageBitmap.width;
          const height = imageBitmap.height;
          canvas.width = width;
          canvas.height = height;

          // Draw the image frame onto the canvas
          context.drawImage(imageBitmap, 0, 0, canvas.width, canvas.height);

          // Convert canvas to base64 image
          const imageData = canvas.toDataURL('image/png');

          // Set the captured image URL to display it in the component
          setCapturedImage(imageData);

          // Send the base64 image to the Flask backend
          axios
            .post('https://8d85-103-92-43-226.ngrok-free.app/upload-image', {
              image: imageData.split(',')[1], // remove 'data:image/png;base64,' prefix
            })
            .then((response) => {
              setResponseMessage(response.data.message);
              setEmotion(response.data.result)
            })
            .catch((error) => {
              setResponseMessage("Error uploading image");
              console.error("Error:", error);
            });
        })
        .catch((error) => {
          console.error("Error capturing frame:", error);
          setResponseMessage("Error capturing frame");
        });
    }
  };

  // Start taking snapshots every 10 seconds
  const startCapturing = () => {
    if (!isCapturing) {
      startWebcam();
      intervalRef.current = setInterval(captureAndSendImage, 2000); // Capture every 2 seconds
      setIsCapturing(true); // Update state to indicate capturing is active
      console.log('Capturing started');
    }
  };

  // Stop capturing and log webcam state
  const stopCapturing = () => {
    stopWebcam();
    console.log('Capturing process stopped');
    setResponseMessage('Capturing stopped');
  };

  useEffect(() => {
    startWebcam();
    return () => stopWebcam(); // Cleanup on component unmount
  }, []);

  return (
    <div>
      <h1>Webcam Image Capture and Upload</h1>
      <canvas ref={canvasRef} style={{ display: 'none' }} width={640} height={480}></canvas>

      {/* Display the captured image */}
      {capturedImage && (
        <div>
          <h2>Captured Image:</h2>
          <img src={capturedImage} alt="Captured" style={{ width: '100%', maxWidth: '640px' }} />
        </div>
      )}

      {/* Buttons */}
      <button onClick={startCapturing} disabled={isCapturing}>Start Capturing</button>
      <button onClick={stopCapturing}>Stop Capturing</button>

      <p>{responseMessage}</p>
      <h3>
        current-emotion: {emotion}
      </h3>     

      {/* Logging webcam state */}
      <div>
        <p>Webcam state: {isCapturing ? 'Capturing' : 'Stopped'}</p>
      </div>
    </div>
  );
};

export default WebcamCapture;
