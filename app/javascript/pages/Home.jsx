import React from "react";
import Header from "./_Header";
import {Link} from "react-router";

const Home = () => {
    return (
        <>
            <div className="bg-russian-violet h-screen overflow-hidden">
                <Header/>
                <div className="sm:w-4/5 mx-5 sm:mx-auto h-full flex flex-col justify-center">
                    <h1
                        className="text-white  font-bold font-unbounded w-auto
                        text-xl sm:text-5xl "
                    >
                        GENERATE YOUR<br/>
                        <span
                            className="text-pink text-4xl sm:text-8xl  inline-block"
                        >
                            TEXTURE ATLAS
                        </span>
                    </h1>
                    <p className="text-sm sm:text-xl font-unbounded text-timberwolf mt-4 sm:mt-8 mb-10 sm:mb-20">
                        Create seamless texture atlases in seconds with our free online generator!
                        Perfect for game developers, designers, and artists, our tool automatically packs your textures into optimized atlases, reducing draw calls and improving performance.
                        Customize your layout with an intuitive interface — no installation required. Let's make some atlases!
                    </p>

                    <Link to="/user"
                          className="bg-lilac font-unbounded  text-white tracking-widest font-medium
                                     px-7 py-4 place-self-center justify-self-center
                                      rounded-2xl block
                                      shadow-pink shadow-button-big
                                      transition duration-300 ease-in-out hover:scale-110">
                        START NOW
                    </Link>
                </div>
            </div>
        </>
    );
}

export default Home;