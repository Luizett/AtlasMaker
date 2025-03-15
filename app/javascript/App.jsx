import React from 'react';
import {BrowserRouter as Router, Routes, Route} from "react-router";
import Home from "./pages/Home";
import Atlas from "./pages/Atlas";

const App = () => {
    return (
        <Router>
            <Routes>
                <Route path="/" element={<Home />} />
                <Route path="/images" element={<Atlas />} />
            </Routes>
        </Router>
    );
}
export default App;
// const click = ()=>{
//     alert("Hello from React!")
// }
// return (
//   <div className="flex flex-col items-center justify-center min-h-screen bg-timberwolf">
//     <h1 className="text-xl text-amber-700 font-roboto">Hello, world!</h1>
//
//     <p className="text-gray-700 font-unbounded">This is a simple React app using Tailwind CSS.</p>
//     <ul className="list-disc list-inside">
//       <li>Item 1</li>
//       <li>Item 2</li>
//       <li>Item 3</li>
//     </ul>
//     <button onClick={click} className="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded">
//       Click Me
//     </button>
//     <p className="text-gray-500">This is a paragraph with some gray text.</p>
//   </div>
// );