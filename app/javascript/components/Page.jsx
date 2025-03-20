import React from "react";
const Page = (props) => {
    return (
        <div className="py-10 px-12 relative bg-russian-violet h-full overflow-hidden">
            <h1 className="text-pink text-3xl font-medium font-unbounded">
                {props.title} / /
            </h1>
            {props.children}
        </div>
    )
}

export default Page;