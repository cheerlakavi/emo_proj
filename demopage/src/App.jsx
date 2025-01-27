import { useState } from 'react'; 
import WebcamCapture from './SendData';
import './App.css';

function App() {
  return (
    <>
      <h1>Demo page for emotional analysis</h1>
      <p>
          ( In <code>React</code> )
      </p>
      <WebcamCapture />
    </>
  );
}

export default App;