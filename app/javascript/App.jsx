import React from 'react';
function App() {
  const click = ()=>{
      alert("Hello from React!")
  }
  return (
    <div className="flex flex-col items-center justify-center min-h-screen bg-gray-100">
      <h1 className="text-xl text-amber-700">Hello, world!

      <p className="text-gray-700">This is a simple React app using Tailwind CSS.</p>
      <ul className="list-disc list-inside">
        <li>Item 1</li>
        <li>Item 2</li>
        <li>Item 3</li>
      </ul>
      <button onClick={click} className="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded">
        Click Me
      </button>
      <p className="text-gray-500">This is a paragraph with some gray text.</p>  </h1>
    </div>
  );
}
export {App}