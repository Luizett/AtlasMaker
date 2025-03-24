import React from "react";

const Popup = (props) => {

    return (
        <div id={props.id} className="absolute w-full h-screen overflow-hidden bg-gray-600 opacity-50">
            <div className="m-auto bg-ultra-violet opacity-100">
                {props.children}
            </div>
        </div>
    );
}

export default Popup;