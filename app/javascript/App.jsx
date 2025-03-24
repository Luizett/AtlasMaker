import React, {useEffect} from 'react';
import {BrowserRouter as Router, Routes, Route} from "react-router";
import Home from "./pages/Home";
import Atlas from "./pages/Atlas";
import AtlasPage from "./pages/AtlasPage";
import UserPage from "./pages/UserPage";
import AuthPage from "./pages/AuthPage";
import {Provider, useDispatch} from "react-redux";
import store from "./slices/store"
import {sessionEnter} from "./slices/sessionSlice";

// TODO
// настроить загрузку токена в локал сторадж и при загрузке страницы смотреть в локал сторадж и искать там токен, проверять его и вписывать юзера в стор
const App = () => {

    const dispatch = useDispatch()
    // была ли текущая сессия
    useEffect(() => {
        const token = window.localStorage.getItem('token')
        if (token) {
            fetch("/session", {
                method: "GET",
                headers: {
                    "Authorization": token,
                }
            }).then(res => res.json())
              .then(data => {
                  console.log(data)
                  dispatch(sessionEnter({
                      user_id: data.user_id,
                      username: data.username,
                      token
                  }))
              })
                .catch(err => console.log(err))
        }
    }, [])

    return (
        // <Provider store={store}>
            <Router>
                <Routes>
                    <Route path="/" element={<Home />} />
                    <Route path="/auth" element={<AuthPage />} />
                    <Route path="/images" element={<Atlas />} />
                    <Route path="/atlas" element={<AtlasPage/> } />
                    <Route path="/user" element={  <UserPage/> } />
                </Routes>
            </Router>
        // </Provider>
    );
}
export default App;
