import React from "react";

const Button = (props) => {
    let clazz = ""
    switch (props.type) {
        case 'violetBig':
            clazz = "bg-lilac"
            break;
        case 'violet':
            clazz = "bg-lilac text-lg text-white font-medium font-unbounded shadow-pink shadow-button rounded-full px-5 py-2"
            break;
        case 'change':
            clazz = "bg-lilac text-md text-cherry rounded-full px-7 py-3 w-[230px] hover:bg-cherry hover:text-reddish hover:inset-shadow-[0px_0px_5px] hover:inset-shadow-reddish";
            break;
        case 'delete':
    }

    const icon = props.icon?
        <img src={props.icon} alt=""/>
        : null;
    return (
         <button className={`${clazz}`}
                 type={props.btnType? props.btnType : null}
        //<button className="bg-lilac text-md text-cherry rounded-full px-7 py-3 w-[230px] hover:bg-cherry hover:text-reddish hover:inset-shadow-[0px_0px_20px] hover:inset-shadow-reddish"
                onClick={props.onClick}>
            {icon}
            {props.children}
        </button>
    )
}

export default Button;