import React from "react";
import Page from "../components/Page";
import Header from "./_Header";
import Button from "../components/Button";
import List from "../components/List";



const AtlasPage = () => {
    return (
        <div className="font-unbounded min-h-screen bg-russian-violet">
            <Header />
            <Page title="texture atlas">
                <div className="-mt-10 flex justify-end">
                    <Button type="violet" >Export</Button>
                </div>

                <div className="mt-6 mb-11">
                    <div className="absolute bg-pink h-1 w-screen left-0 mt-5 "></div>
                    <p className=" absolute bg-light-gray border-pink border-4 text-black text-xl rounded-xl z-10 py-1.5 px-3">
                        filename
                    </p>
                </div>
                <div className="bg-timberwolf rounded-xl border-pink border-dashed border-5 mt-24" >
                    <div className="m-5 aspect-3/1"
                         style={{
                             backgroundImage: `url(\"/images/transparent.png\")`,
                             backgroundSize: "cover",
                    }}>
                        <img src="" alt=""/>

                    </div>
                </div>
                <div className="mt-8">
                    <List title="IMAGES "/>
                </div>

            </Page>


        </div>

    );

}

export default AtlasPage