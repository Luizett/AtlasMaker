import React, {useEffect, useState} from "react";
import useFetch from "../services/useFetch";
import {useNavigate} from "react-router";

import {useDispatch, useSelector} from "react-redux";
import {changeAvatar, changeUsername} from "../slices/userSlice";
import {sessionLeave} from "../slices/sessionSlice";
import {resetAll} from "../slices/userSlice";

import Header from "./_Header";
import Page from "../components/Page";
import Button from "../components/Button";
import Popup from "../components/Popup";
import ListAtlases from "../components/List/ListAtlases";


const UserPage = () => {
    const {username, user_id, avatar} = useSelector(state => state.user);
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
                        <div className="w-[200px] h-[200px] rounded-full bg-timberwolf mx-auto aspect-square overflow-hidden">
                            <img src={avatar} width={200} height={200}
                                 className="object-fill"
                            />
                        </div>

                        <div className="absolute bg-pink h-1 w-screen left-0  "></div>
                        <p style={{width: "fit-content",}}
                           className=" absolute bg-russian-violet border-pink border-4 text-white text-xl  rounded-full z-10 py-1.5 px-3 -mt-5 mx-auto left-0 right-0">
                            {username}
                        </p>
                    </div>

                    <div className="flex flex-row gap-7 mt-16 justify-center flex-wrap">
                        <Button type="change" className="w-[230px]" onClick={() => setPopup('username')}>
                            change username
                        </Button>
                        <Button type="change" className="w-[230px]"   onClick={() => setPopup('password')}>
                            change password
                        </Button>
                        <Button type="change" className="w-[230px]"  onClick={() => setPopup('avatar')}>
                            change avatar
                        </Button>
                        <Button type="change" className="w-[230px]"  onClick={onExit}>
                            exit account
                        </Button>
                        <Button type="change" className="w-[230px]"  onClick={() => setPopup('delete')}>
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

        request("/user/username", "PATCH", formData)
            .then(data => {
                if (data.error_username) {
                    throw data.error_username;
                }
                else {
                    // обновление данных в сторе
                    dispatch(changeUsername(data.username));
                    e.target.reset();
                    props.setPopup('none');
                }
            }).catch(err => {
                document.getElementById("loginPopup-error").textContent = err
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
                <span id="loginPopup-error" className="text-sm text-reddish font-light place-self-start h-5 pl-2 text-start"></span>
                <div className="mx-auto mt-6">
                    <Button type="change" btnType="submit">Change username</Button>
                </div>
            </form>
        </Popup>
    )
}

const PasswordPopup = (props) => {
    const {request} = useFetch();
    const onChangePassword = (e) => {
        e.preventDefault();
        const formData = new FormData(e.target)

        request("/user/password", "PATCH", formData)
            .then(data => {
                if (data.error_password) {
                    throw data.error_password;
                }
                else {
                    e.target.reset();

                    props.setPopup('none');
                }
            }).catch(err => {
            document.getElementById("passwordPopup-error").textContent = err
        })
    }

    return (
        <Popup id="passwordPopup" closePopup={() => props.setPopup('none')}>
            <p className="text-lg font-medium font-unbounded mt-2 mb-4 text-center text-nowrap mx-7">
                Change your password
            </p>
            <form onSubmit={onChangePassword} className="flex flex-col gap-3 ">
                <label htmlFor="old_password"
                       className="text-start text-sm font-medium font-unbounded ">
                    Old password
                    <input
                        name="old_password" type="password" required={true}
                        className="border-2 border-pink font-roboto rounded-md px-3 py-2 w-full"
                    />
                </label>
                <label htmlFor="new_password"
                       className="text-start text-sm font-medium font-unbounded">
                    New password
                    <input
                        name="new_password" type="password" required={true}
                        className="border-2 border-pink font-roboto rounded-md px-3 py-2 w-full"
                    />
                </label>

                <span id="passwordPopup-error"
                      className="text-sm text-reddish font-light place-self-start  pl-2 text-center w-full">
                </span>
                <div className="mx-auto ">
                    <Button type="change" btnType="submit">Change password</Button>
                </div>
            </form>
        </Popup>
    )
}

const AvatarPopup = (props) => {
    const dispatch = useDispatch();
    const {request} = useFetch();
    const onChangeAvatar = (e) => {
        e.preventDefault();
        const formData = new FormData(e.target)

        request("/user/avatar", "PATCH", formData)
            .then(data => {
                if (data.error_avatar) {
                    throw data.error_avatar;
                }
                else {
                    e.target.reset();
                    dispatch(changeAvatar(data.avatar))
                    props.setPopup('none');
                }
            }).catch(err => {
            document.getElementById("avatarPopup-error").textContent = err
        })
    }

    return (
        <Popup id="avatarPopup" closePopup={() => props.setPopup('none')}>
            <form onSubmit={onChangeAvatar} className="flex flex-col text-center gap-4 text-lg font-unbounded">
                <label htmlFor="avatar"
                       className="flex flex-col cursor-pointer mt-4">
                    New avatar
                    <input id="avatar" name="avatar" type="file" accept="image/png, image/jpeg"
                           className="hidden " required={true}
                           onChange={(e) => {
                               if (!["image/jpeg", "image/png"].includes(e.target.files[0].type)) {
                                   e.target.value = ""
                                   document.getElementById("avatar-title").innerText = "Set new avatar";
                                   document.getElementById("avatarPopup-error").innerText = "File must be JPG or PNG format.";
                               } else {
                                   document.getElementById("avatarPopup-error").innerText = "";
                                   document.getElementById("avatar-title").innerText = e.target.files[0].name;
                               }
                           }}
                    />
                    <span id="avatar-title"
                          className="border-timberwolf border-dashed border-2 py-8 text-center rounded-md mt-4">
                        Set new avatar
                    </span>
                </label>


                <span id="avatarPopup-error"
                      className="text-sm text-reddish font-light place-self-start  pl-2 text-center w-full">
                </span>
                <Button type="change" btnType="submit" className="w-[280px] mx-auto">Change avatar</Button>
            </form>
        </Popup>
    )
}

const DeletePopup = (props) => {
    const {request} = useFetch();
    const dispatch = useDispatch();
    const navigate = useNavigate();
    const onDelete = () => {


        request("/user", "DELETE")
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
        <Popup id="deletePopup" closePopup={() => props.setPopup('none')}>
            <p className="font-unbounded text-lg text-center mb-4">Are you sure to delete your account?</p>
            <Button type="change" onClick={onDelete}>Yes, delete my account</Button>
        </Popup>
    )
}


export default UserPage;