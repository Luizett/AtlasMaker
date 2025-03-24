import React, {useEffect, useState} from "react";
import Header from "./_Header";
import Page from "../components/Page";
import List from "../components/List";
import Button from "../components/Button";

import store from "../slices/store";
import {useDispatch, useSelector} from "react-redux";
import {redirect, useNavigate} from "react-router";

import {sessionLeave} from "../slices/sessionSlice";
import Popup from "../components/Popup";

const UserPage = () => {
    const {username} = store.getState().session;
    const [popup, setPopup] = useState("none");


    const navigate = useNavigate();
    useEffect(() => {
        if (!username) {
            navigate("/auth");
        }
    }, [])

    const dispatch = useDispatch();


    const onExit = () => {
        dispatch(sessionLeave());
        navigate("/");
    }

    let popupHTML = null;
    switch (popup) {
        case 'login':
            popupHTML = usernamePopup()
            break;
        case 'password':
            popupHTML = passwordPopup()
            break;
        case 'avatar':
            popupHTML = avatarPopup()
            break;
        case 'delete':
            popupHTML = deletePopup()
            break;
        default:
            popupHTML = null;
            break;
    }

    return (
        <div className="font-unbounded min-h-screen bg-russian-violet">
            {popupHTML}
            <Header/>
            <Page title="account">
                <div className="mt-8">
                    <img src="/icons/user.png" width={200} height={200}
                         className="rounded-full bg-timberwolf mx-auto"/>
                    <div className="absolute bg-pink h-1 w-screen left-0  "></div>
                    <p style={{width: "fit-content",}}
                       className=" absolute bg-russian-violet border-pink border-4 text-white text-xl  rounded-full z-10 py-1.5 px-3 -mt-5 mx-auto left-0 right-0">
                        {username}
                    </p>
                </div>

                <div className="flex flex-row gap-7 mt-16 justify-center">
                    <Button type="change" onClick={() => setPopup('login')}>change username</Button>
                    <Button type="change" onClick={() => setPopup('password')}>change password</Button>
                    <label>
                        <input id="avatar" name="avatar" type="file" accept="image/png, image/jpeg" className="hidden"
                               onChange={() => {/* TODO */}}/>
                        <Button type="change">change avatar</Button>
                    </label>
                    {/*<Button type="change">change avatar</Button>*/}
                    <Button type="change" onClick={onExit}>exit account</Button>
                    <Button type="change" onClick={() => setPopup('delete')}>delete account</Button>
                </div>

                <div className="mt-24">
                    <List title="ATLAS "/>
                </div>


            </Page>
        </div>
    );
}

const usernamePopup = (onChange, setPopup) => {

    const onChangeUsername = () => {
        fetch("/user/username")
        setPopup('none')
    }

    return (
        <Popup id="loginPopup">
            <label>New username</label>
            <input/>
            <Button type="change" onClick={onChangeUsername}>Change login</Button>
        </Popup>
    )
}

const passwordPopup = (onChange) => {

    const onChangePassword = () => {

    }

    return (
        <Popup id="loginPopup">
            <label>New password</label>
            <input/>
            <Button type="change" onClick={onChangePassword}>Change password</Button>
        </Popup>
    )
}

const avatarPopup = (onChange) => {

    const onChangePassword = () => {

    }

    return (
        <Popup id="loginPopup">
            <label>New password</label>
            <input/>
            <Button type="change" onClick={onChangePassword}>Change password</Button>
        </Popup>
    )
}

const deletePopup = (onChange) => {

    const onChangePassword = () => {

    }

    return (
        <Popup id="loginPopup">
            <label>New password</label>
            <input/>
            <Button type="change" onClick={onChangePassword}>Change password</Button>
        </Popup>
    )
}


export default UserPage;