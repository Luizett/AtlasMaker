import React, {useEffect} from 'react';

import {useDispatch} from "react-redux";
import {sessionEnter} from "./slices/sessionSlice";
import {setAll} from "./slices/userSlice";

import {BrowserRouter as Router, Routes, Route} from "react-router";
import Home from "./pages/Home";
import Atlas from "./pages/Atlas";
import AtlasPage from "./pages/AtlasPage";
import UserPage from "./pages/UserPage";
import AuthPage from "./pages/AuthPage";

const csrfToken = document.querySelector('meta[name="csrf-token"]').content;


const App = () => {

    const dispatch = useDispatch();

    // была ли текущая сессия
    useEffect(() => {
        const token = window.localStorage.getItem('token')
        console.log(token)
        if (token) {
            fetch("/session", {
                method: "GET",
                headers: {
                    'X-CSRF-Token': csrfToken,
                    Authorization: `Bearer ${token}`
                }
            }).then(res => res.json())
              .then(data => {
                  if (data.errors) {
                      throw new Error(data.errors)
                  }
                  console.log(data)
                  dispatch(sessionEnter(token))
                  dispatch(setAll({
                      user_id: data.user_id,
                      username: data.username,
                      avatar: data.avatar_url
                  }))
              })
                .catch(err => console.log(err))
        }
    }, [])

    return (
        <Router>
            <Routes>
                <Route path="/" element={<Home />} />
                <Route path="/auth" element={<AuthPage />} />
                <Route path="/images" element={<Atlas />} />
                <Route path="/atlas" element={<AtlasPage/> } />
                <Route path="/user" element={  <UserPage/> } />
            </Routes>
        </Router>
    );
}
export default App;
