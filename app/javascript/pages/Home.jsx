import React from "react";
import Header from "./_Header";
import {Link} from "react-router";

const Home = () => {
    return (
        <>
            <div className="bg-russian-violet h-screen overflow-hidden">
                <Header/>

                <div className="w-4/5 mx-auto h-full flex flex-col justify-center">
                    <h1 className="text-white text-5xl font-bold font-unbounded w-auto">
                        GENERATE YOUR<br/>
                        <span className="text-pink text-8xl mt-4 inline-block">
                                TEXTURE ATLAS
                            </span>
                    </h1>
                    <p className="text-xl font-unbounded text-timberwolf mt-8 mb-20">
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


                    {/*<p className="text-timberwolf text-base text-center mt-10 font-unbounded leading-2 font-light">*/}
                    {/*    {"or "}*/}
                    {/*    <Link to="/auth"*/}
                    {/*        className="font-normal underline">*/}
                    {/*        Log In*/}
                    {/*    </Link>*/}
                    {/*    {" to save your works"}*/}
                    {/*</p>*/}
                </div>
            </div>
        </>
    );
}

export default Home;