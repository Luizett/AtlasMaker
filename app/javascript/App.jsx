import React from 'react';
import {BrowserRouter as Router, Routes, Route} from "react-router";
import Home from "./pages/Home";
import Atlas from "./pages/Atlas";
import AtlasPage from "./pages/AtlasPage";
import UserPage from "./pages/UserPage";
import AuthPage from "./pages/AuthPage";

const App = () => {
    return (
        <Router>
            <Routes>
                <Route path="/" element={<Home />} />
                <Route path="/auth" element={<AuthPage />} />
                <Route path="/images" element={<Atlas />} />
                <Route path="/atlas" element={<AtlasPage/> } />
                <Route path="/user" element={<UserPage/> } />
            </Routes>
        </Router>
    );
}
export default App;
