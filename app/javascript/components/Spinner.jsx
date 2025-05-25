import React from "react";

//import "./spinner.css"

const Spinner = ({loadingPercent}) => {
    return (
        <div className="flex flex-col h-full justify-center items-center">
            <div className="spinner">
                <div></div>
                <div></div>
                <div></div>
                <div></div>
                <div></div>
            </div>
            <p className="-mt-5 text-sm">
                {loadingPercent}%
            </p>
        </div>
    );
}

export default Spinner;