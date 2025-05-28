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
    const [isMessageBoxVisible, setIsMessageBoxVisible] = useState(false);
    const [messageBoxMessage, setMessageBoxMessage] = useState("Registration ended successfully!");

    const {token} = useSelector(state => state.session);

    const navigate = useNavigate();
    const dispatch = useDispatch();
    const {request} = useFetch()

    useEffect(() => {
        if (token) {
            navigate("/user");
        }
    }, [token])

    const onRegister = (e) => {
        e.preventDefault();

        const requestBody = new FormData(e.target)

        request("/auth/new", "POST", requestBody)
            .then(data => {
                if (data.message) {
                    setFormType("login")
                    e.target.reset()
                    document.getElementById("username-error").innerText =  ""
                    document.getElementById("password-error").innerText =  ""
                    document.getElementById("avatar-error").innerText =  ""
                    setMessageBoxMessage("Registration ended successfully!")
                    setIsMessageBoxVisible(true)
                }
                else {
                    throw data
                }
            })
            .catch(error => {
                document.getElementById("username-error").innerText = error.error_username || ""
                document.getElementById("password-error").innerText = error.error_password || ""
                document.getElementById("avatar-error").innerText = error.error_avatar || ""
            })
    }

    const onLogIn = (e) => {
        e.preventDefault();
        const requestBody = new FormData(e.target)
        request("/auth/login", "POST", requestBody)
            .then(data => {
                setMessageBoxMessage("")
                setIsMessageBoxVisible(false)
                e.target.reset();
                dispatch(sessionEnter(data.token))
                dispatch(setAll(
                    {
                        user_id: data.user_id,
                        username: data.username,
                        avatar: data.avatar_url
                    }
                ))
                window.localStorage.setItem("token", data.token)
            })
            .catch(error => {
                setMessageBoxMessage("Invalid username or password")
                setIsMessageBoxVisible(true)
            })
    }

    const form = formType === 'register' ?
        (
            <>
                <form id="register" onSubmit={onRegister} className="flex flex-col gap-4">
                    <label className="flex flex-col font-medium">
                        username
                        <input id="username" name="username"
                               required={true} minLength={3} maxLength={20} pattern="[A-Za-z]*" placeholder="awesomName"
                               className="border-timberwolf border-2 rounded-md px-3 py-2 font-roboto invalid:border-red-600"
                               onChange={(e) => {
                                   document.getElementById("username-error").innerText = e.target.validationMessage;
                               }}
                        />
                        <span id="username-error" className="text-xs text-reddish font-light place-self-start mt-1 pl-2"></span>
                    </label>

                    <label className="flex flex-col font-medium">
                        password
                        <input id="password" name="password" type="password"
                               required={true} minLength={4} maxLength={20}
                               className="border-timberwolf border-2 rounded-md px-3 py-2 font-roboto invalid:border-red-600"
                               onChange={(e) => {
                                   document.getElementById("password-error").innerText = e.target.validationMessage;
                               }}/>
                        <span id="password-error" className="text-xs text-reddish font-light place-self-start mt-1 pl-2"></span>
                    </label>


                    <label htmlFor="avatar" className="flex flex-col cursor-pointer mt-4">
                        <input id="avatar" name="avatar" type="file" accept="image/png, image/jpeg" className="hidden"
                               onChange={(e) => {
                                   if (!["image/jpeg", "image/png"].includes(e.target.files[0].type)) {
                                       e.target.value = ""
                                       document.getElementById("avatar-error").innerText = "File must be in JPG or PNG format.";
                                   } else {
                                       document.getElementById("avatar-error").innerText = "";
                                       document.getElementById("avatar-title").innerText = e.target.files[0].name;
                                   }
                                }}
                        />
                        <span id="avatar-title" className="border-timberwolf border-dashed border-2 py-8 text-center rounded-md">
                            Set user picture
                        </span>
                        <span id="avatar-error" className="text-xs text-reddish font-light place-self-start mt-1 pl-2"></span>
                    </label>

                    <div className="flex justify-center mt-4">
                        <Button type="violet">Sign Up</Button>
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
                        <input id="password" name="password" type="password" required={true}
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
                                    setFormType('register');
                                    setIsMessageBoxVisible(false);
                                }}
                                className={`border-pink border-2 rounded-l-xl px-6 py-3 ${formType === 'register' ? "bg-pink text-russian-violet" : "text-pink"}`}>
                            Sign In
                        </button>
                        <button type="button"
                                onClick={() => {
                                    setFormType('login');
                                    setIsMessageBoxVisible(false);
                                }}
                                className={`border-pink border-2 rounded-r-xl px-6 py-3 ${formType === 'login' ? "bg-pink text-russian-violet" : "text-pink"}`}>
                            Log In
                        </button>
                    </div>
                    <div className="flex flex-col border-4 border-pink rounded-2xl p-8 mx-auto w-min min-w-64">
                        {form}
                    </div>
                    {isMessageBoxVisible ?
                        <div className="border-timberwolf border-2 rounded-2xl p-4 w-min min-w-64 text-center mt-5 mx-auto ">
                            {messageBoxMessage}
                        </div>
                        : ""
                    }
                </div>
            </div>
        </>
    );
}


export default AuthPage;