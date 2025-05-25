import React from "react";

const Button = (props) => {
    let clazz = ""
    switch (props.type) {
        case 'violetBig':
            clazz = "bg-lilac"
            break;
        case 'violet':
            clazz = `bg-lilac 
                     text-sm sm:text-lg text-white font-medium font-unbounded 
                     shadow-pink shadow-button rounded-full 
                     px-3 sm:px-5 py-1 sm:py-2 cursor-pointer
                     h-min`
            break;
        case 'change':
            clazz = `cursor-pointer bg-lilac text-cherry font-unbounded 
                     text-sm sm:text-base text-nowrap
                     px-4 sm:px-7 py-2 sm:py-3 
                     rounded-full
                     hover:bg-cherry hover:text-reddish hover:inset-shadow-[0px_0px_5px] hover:inset-shadow-reddish`;
            break;
        case 'delete':
    }

    const icon = props.icon?
        <img src={props.icon} alt=""/>
        : null;

    return (
         <button className={`${clazz} ${props.className} hover:scale-105 `}
                 type={props.btnType? props.btnType : null}
                 onClick={props.onClick}>
            {icon}
            {props.children}
        </button>
    )
}

export default Button;