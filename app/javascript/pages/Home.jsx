import React from "react";
import Header from "./_Header";
import {Link} from "react-router";

const Home = () => {
    return (
        <>
            <Header />
            <div className="bg-russian-violet min-h-screen ">
                <h1 className="text-white text-5xl">
                    GENERATE YOUR
                    <span className="text-pink text-8xl">
                        TEXTURE ATLAS
                    </span>
                </h1>
                <p className="text-xl">
                    Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore
                    et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut
                    aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse
                    cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in
                    culpa qui officia deserunt mollit anim id est laborum.
                </p>
                <Link to="/atlas" className="bg-lilac">START NOW</Link>
                <p className="text-timberwolf text-base">
                    or <Link to="/" >Log In</Link> to save your works
                </p>
            </div>
        </>
    );
}

export default Home;