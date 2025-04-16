import React, {useEffect, useState} from "react";
import useFetch from "../services/useFetch";
import {useNavigate} from "react-router";

import {useDispatch, useSelector} from "react-redux";
import {changeUsername} from "../slices/userSlice";
import {sessionLeave} from "../slices/sessionSlice";
import {resetAll} from "../slices/userSlice";

import Header from "./_Header";
import Page from "../components/Page";
import Button from "../components/Button";
import Popup from "../components/Popup";
import ListAtlases from "../components/List/ListAtlases";


const UserPage = () => {
    const {username, user_id} = useSelector(state => state.user);
    const {token} = useSelector(state => state.session);

    const [popup, setPopup] = useState("none");

    const dispatch = useDispatch();
    const navigate = useNavigate();
    useEffect(() => {
        if (!token) {
            navigate("/auth");
        }
    }, [])

    const onExit = () => {
        dispatch(sessionLeave());
        dispatch(resetAll());
        window.localStorage.removeItem("token");
        navigate("/");
    }

    const changePopup = (type) => {
        setPopup(type)
    }

    let popupHTML = null;
    switch (popup) {
        case 'username':
            popupHTML = <UsernamePopup setPopup={setPopup} userId={user_id}/>
            break;
        case 'password':
            popupHTML = <PasswordPopup setPopup={setPopup} userId={user_id}/>
            break;
        case 'avatar':
            popupHTML = <AvatarPopup setPopup={setPopup} userId={user_id}/>
            break;
        case 'delete':
            popupHTML = <DeletePopup setPopup={setPopup} userId={user_id}/>
            break;
        default:
            popupHTML = null;
            break;
    }

    return (
        <>
            <div className="font-unbounded min-h-screen bg-russian-violet relative">

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
                        <Button type="change" onClick={() => changePopup('username')}>
                            change username
                        </Button>
                        <Button type="change" onClick={() => setPopup('password')}>
                            change password
                        </Button>
                        <Button type="change" onClick={() => setPopup('avatar')}>
                            change avatar
                        </Button>
                        <Button type="change" onClick={onExit}>
                            exit account
                        </Button>
                        <Button type="change" onClick={() => setPopup('delete')}>
                            delete account
                        </Button>
                    </div>

                    <div className="mt-24">
                        <ListAtlases />
                    </div>
                </Page>
            </div>
            {popupHTML}
        </>
    );
}

const UsernamePopup = (props) => {
    const dispatch = useDispatch();
    const {request} = useFetch();
    const onChangeUsername = (e) => {
        e.preventDefault();
        const formData = new FormData(e.target)
        formData.append('user_id', props.userId);

        request("/user/username", "PATCH", formData)
            .then(data => {
                // обновление данных в сторе
                dispatch(changeUsername(data.username));
                e.target.reset();
                props.setPopup('none');
            }).catch(err => {
                document.getElementById("loginPopup-error").textContent = 'Username is already taken'
            })
    }

    return (
        <Popup id="loginPopup" closePopup={() => props.setPopup('none')}>
            <form onSubmit={onChangeUsername} className="flex flex-col text-center">
                <label htmlFor="username"
                       className="text-lg font-medium font-unbounded mb-4">
                    New username
                </label>
                <input
                    name="username"
                    className="border-2 border-pink font-roboto rounded-md px-3 py-2"
                />
                <span id="loginPopup-error" className="text-sm text-reddish font-light place-self-start h-5 pl-2"></span>
                <div className="mx-auto mt-4">
                    <Button type="change" btnType="submit">Change username</Button>
                </div>
            </form>
        </Popup>
    )
}

const PasswordPopup = (onChange) => {
// todo password popup
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

const AvatarPopup = (onChange) => {
// todo avatar popup
    const onChangeAvatar = () => {

    }

    return (
        <Popup id="loginPopup">
            <label>New password</label>
            <input/>
            <Button type="change" onClick={onChangeAvatar}>Change avatar</Button>
        </Popup>
    )
}

const DeletePopup = (props) => {
    const {request} = useFetch();
    const dispatch = useDispatch();
    const navigate = useNavigate();
    const onDelete = () => {
        let formData = new FormData();
        formData.append('user_id', props.userId);

        request("/user","DELETE", formData)
            .then(data => {
                props.setPopup('none');
                dispatch(sessionLeave());
                dispatch(resetAll());
                window.localStorage.removeItem("token");
                navigate("/");
            })
            .catch(err => console.log(err.message))
    }

    return (
        <Popup id="loginPopup">
            <p>Are you sure to delete your account?</p>
            <Button type="change" onClick={onDelete}>Yes, delete my account</Button>
        </Popup>
    )
}


export default UserPage;