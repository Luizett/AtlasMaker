import React from "react";
import Header from "./_Header";
import Page from "../components/Page";
import List from "../components/List";
import Button from "../components/Button";

const UserPage = () => {
    return (
        <div className="font-unbounded min-h-screen bg-russian-violet">
            <Header />
            <Page title="account">
                <div className="mt-8">
                    <img src="/icons/user.png" width={200} height={200}
                         className="rounded-full bg-timberwolf mx-auto"/>
                    <div className="absolute bg-pink h-1 w-screen left-0  "></div>
                    <p style={{ width: "fit-content",}}
                        className=" absolute bg-russian-violet border-pink border-4 text-white text-xl  rounded-full z-10 py-1.5 px-3 -mt-5 mx-auto left-0 right-0">
                        username
                    </p>
                </div>

                <div className="flex flex-row gap-7 mt-16 justify-center">
                    <Button type="change">change login</Button>
                    <Button type="change">change password</Button>
                    <Button type="change">change avatar</Button>
                </div>

                <div className="mt-24">
                    <List title="ATLAS "/>
                </div>


            </Page>
        </div>
    );
}



export default UserPage;