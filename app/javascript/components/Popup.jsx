import React from "react";

const Popup = (props) => {
    return (
        <div id={props.id}
             className="fixed overflow-hidden bg-overlaying top-0 bottom-0 left-0 right-0 z-20">
            <div
                className="absolute left-1/2 rigt-1/2 -translate-x-1/2 top-1/2 mx-auto
                            p-6 rounded-xl w-1/5
                            bg-cherry text-white flex flex-col ">
                <button className="place-self-end" onClick={props.closePopup}>
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <path d="M18 6L6 18" stroke="#ffF" strokeWidth="2" strokeLinecap="round"
                              strokeLinejoin="round"/>
                        <path d="M6 6L18 18" stroke="#ffF" strokeWidth="2" strokeLinecap="round"
                              strokeLinejoin="round"/>
                    </svg>
                </button>
                {props.children}
            </div>
        </div>
    );
}

export default Popup;