import React from "react";
const Page = (props) => {
    return (
        <div className="py-3 px-4  sm:py-10 sm:px-12 relative bg-russian-violet h-full overflow-hidden">
            <h1 className="text-pink text-xl sm:text-3xl font-medium font-unbounded">
                {props.title} / /
            </h1>
            {props.children}
        </div>
    )
}

export default Page;