import React, {useEffect, useState} from "react";
import {useNavigate} from "react-router";
import useFetch from "../services/useFetch";

import {sessionEnter} from "../slices/sessionSlice";
import {useDispatch, useSelector} from "react-redux";
import {setAll} from "../slices/userSlice";

import Header from "./_Header";
import Button from "../components/Button";

const AuthPage = () => {
    const [formType, setFormType] = useState('login');
    const {token} = useSelector(state => state.session);

    const navigate = useNavigate();
    const dispatch = useDispatch();
    const {request} = useFetch()

    useEffect(() => {
        if (token) {
            console.log("redirect to user")
            navigate("/user");
        }
    }, [])

    const onRegister = (e) => {
        e.preventDefault();

        const requestBody = new FormData(e.target)

        request("/auth/new", "POST", requestBody)
            .then(data => {
                setFormType("login")
                    // TODO добавить валидацию полей и вывод ошибок в зависимости от типа ошибки
                    // todo добавить подсказку об успешной решистрации
            })
            .catch(error => console.log(error))

        e.target.reset()
    }

    const onLogIn = (e) => {
        e.preventDefault();
        const requestBody = new FormData(e.target)
        request("/auth/login", "POST", requestBody)
            .then(data => {
                dispatch(sessionEnter(data.token))
                dispatch(setAll(
                    {
                        user_id: data.user_id,
                        username: data.username,
                        avatar: data.avatar_url
                    }
                ))
                window.localStorage.setItem("token", data.token)
                navigate("/user")
            })
            .catch(error => console.log(error))
        e.target.reset();
    }

    const form = formType === 'register' ?
        (
            <>
                <form id="register" onSubmit={onRegister} className="flex flex-col gap-4">
                    <label className="flex flex-col font-medium">
                        username
                        <input id="username" name="username" required={true}
                               className="border-timberwolf border-2 rounded-md px-3 py-2 font-roboto"/>
                        <span className="error hidden"></span>
                    </label>

                    <label className="flex flex-col font-medium">
                        password
                        <input id="password" name="password" type="password"
                               className="border-timberwolf border-2 rounded-md px-3 py-2 font-roboto"/>
                        <span className="error hidden"></span>
                    </label>


                    <label htmlFor="avatar" className="flex flex-col cursor-pointer mt-4">
                        <input id="avatar" name="avatar" type="file" accept="image/png, image/jpeg" className="hidden"/>
                        <span className="border-timberwolf border-dashed border-2 py-8 text-center rounded-md">
                            Set user picture
                        </span>
                        <span className="error hidden"></span>
                    </label>

                    <div className="flex justify-center mt-4">
                        <Button type="violet">Sign In</Button>
                    </div>
                </form>
            </>
        )
        :
        (
            <>
                <form id="login" onSubmit={onLogIn} className="flex flex-col gap-4">
                    <label className="flex flex-col font-medium">
                        username
                        <input id="username" name="username" required={true}
                               className="border-timberwolf border-2 rounded-md px-3 py-2 font-roboto"/>
                        <span className="error hidden"></span>
                    </label>

                    <label className="flex flex-col font-medium">
                        password
                        <input id="password" name="password" type="password"
                               className="border-timberwolf border-2 rounded-md px-3 py-2 font-roboto"/>
                        <span className="error hidden"></span>
                    </label>

                    <div className="flex justify-center mt-4">
                        <Button type="violet">Log In</Button>
                    </div>
                </form>
            </>
        );

    return (
        <>
            <div className="bg-russian-violet text-white min-h-screen h-screen font-unbounded">
                <Header/>

                <div className="flex flex-col justify-center h-5/6 ">
                    <div className="rounded-2xl flex justify-center mb-4">
                        <button type="button"
                                onClick={() => {
                                    setFormType('register')
                                }}
                                className={`border-pink border-2 rounded-l-xl px-6 py-3 ${formType === 'register' ? "bg-pink text-russian-violet" : "text-pink"}`}>
                            Sign In
                        </button>
                        <button type="button"
                                onClick={() => {
                                    setFormType('login')
                                }}
                                className={`border-pink border-2 rounded-r-xl px-6 py-3 ${formType === 'login' ? "bg-pink text-russian-violet" : "text-pink"}`}>
                            Log In
                        </button>
                    </div>
                    <div className="flex flex-col border-4 border-pink rounded-2xl p-8 mx-auto w-1/4">
                        {form}
                    </div>
                </div>
            </div>
        </>
    );
}


export default AuthPage;