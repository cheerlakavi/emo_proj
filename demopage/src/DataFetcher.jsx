import { useEffect } from 'react';

const DataFetcher = ({ setData, interval = 5000 }) => {
  useEffect(() => {
    // Function to fetch data
    const fetchData = () => {
      fetch('http://localhost:5000/upload-image')
        .then(response => response.json())
        .then(data => setData(data.result)) // Update state with fetched data
        .catch(error => console.error("Error fetching data:", error));
    };

    // Fetch data initially and then at regular intervals
    fetchData();
    const polling = setInterval(fetchData, interval);

    // Cleanup interval on component unmount
    return () => clearInterval(polling);
  }, [setData, interval]); // Re-run effect if setData or interval changes

  return null; // This component does not render anything directly
};

export default DataFetcher;
