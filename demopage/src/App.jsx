import { useState } from 'react';
import DataFetcher from './DataFetcher';  // Import the DataFetcher component
import WebcamCapture from './SendData';
import './App.css';

function App() {
  const [data, setData] = useState("No data available yet.");

  return (
    <>
      <h1>Demo page for emotional analysis</h1>
      <p>
          ( In <code>React</code> )
      </p>
      <DataFetcher setData={setData} />
      <p>{data}</p>
      <br />
      <WebcamCapture />
    </>
  );
}

export default App;