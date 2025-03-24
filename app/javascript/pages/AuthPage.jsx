import React, {useState} from "react";
import Header from "./_Header";
import Button from "../components/Button";
import {useNavigate} from "react-router";
const csrfToken = document.querySelector('meta[name="csrf-token"]').content;

import {sessionEnter} from "../slices/sessionSlice";
import {useDispatch} from "react-redux";

const AuthPage = () => {
    const [message,setMessage] = useState("");
    const [formType, setFormType] = useState('login');

    let navigate = useNavigate();
    const dispatch = useDispatch();

    const onRegister = (e) => {
        e.preventDefault();

        const formData = new FormData(e.target)
        fetch("/auth/new", {
            method: 'POST',
            body: formData,
            headers: {
                'X-CSRF-Token': csrfToken,
            }
        })
            .then(res => res.json())
            .then(data => {
                console.log(data)
                if (!data.errors) {
                    // TODO
                    // добавить валидацию полей и вывод ошибок в зависимости от типа ошибки
                    // добавить подсказку об успешной решистрации

                    setFormType("login")

                }
                else {
                    throw new Error("error while fetch register")
                }
            })
            .catch(error => {
                console.log(error)
            })
        e.target.reset()

    }

    const onLogIn = (e) => {
        e.preventDefault();
        const formData = new FormData(e.target)
        fetch("/auth/login", {
            method: 'POST',
            body: formData,
            headers: {
                'X-CSRF-Token': csrfToken,
            }
        })
            .then(res => res.json())
            .then(data => {
                console.log(data)
                if (!data.errors) {
                    dispatch(sessionEnter(data))
                    window.localStorage.setItem("token", data.token)
                    navigate("/user")
                }
                else {
                    throw new Error("error while fetch login")
                }
            })
            .catch(error => {
                console.log(error)
            })
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