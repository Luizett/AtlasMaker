import React from "react";
import Header from "./_Header";
import {Link} from "react-router";

const Home = () => {
    return (
        <>

            <div className="bg-russian-violet min-h-screen flex flex-col align-middle">
                <Header />
                <div className="w-4/5 mx-auto">
                    <h1 className="text-white text-5xl font-bold font-unbounded mt-60 w-auto">
                        GENERATE YOUR<br/>
                        <span className="text-pink text-8xl mt-4 inline-block">
                        TEXTURE ATLAS
                    </span>
                    </h1>
                    <p className="text-xl font-unbounded text-timberwolf mt-8 mb-20">
                        Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut
                        labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris
                        nisi ut aliquip ex ea commodo consequat.
                    </p>

                    <Link to="/atlas"
                          className="bg-lilac font-unbounded  text-white tracking-widest font-medium
                                     px-7 py-4 place-self-center justify-self-center
                                      rounded-2xl block
                                      shadow-pink shadow-button-big">
                            START NOW
                    </Link>


                    <p className="text-timberwolf text-base text-center mt-10 font-unbounded leading-2 font-light">
                        {"or "}
                        <Link to="/auth"
                            className="font-normal underline">
                            Log In
                        </Link>
                        {" to save your works"}
                    </p>
                </div>

            </div>
        </>
    );
}

export default Home;