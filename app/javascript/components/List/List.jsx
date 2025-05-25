import React from "react";

import Button from "../Button";
import ListViewButton from "./ListViewButton";

const List = (props) => {
    return (
        <>
            <div className="flex flex-wrap justify-between align-bottom  gap-1">
                <h2 className="text-xl sm:text-3xl text-pink font-medium pt-2">
                    {props.title}
                    <span className="text-white">
                        list
                    </span>
                </h2>
                <div className="flex sm:flex-row items-center sm:gap-5 align-middle justify-end">
                    <ListViewButton type="list"
                                    active={props.activeView}
                                    onClick={() => props.setActiveView('list')}/>
                    <ListViewButton type="gallery"
                                    active={props.activeView}
                                    onClick={() => props.setActiveView('gallery')}/>
                    <Button type="violet" onClick={props.onAddElem} className="ml-[10px] sm:ml-0">
                        {props.btnTitle}
                    </Button>
                </div>
            </div>
            <div className="absolute bg-pink h-1 w-screen left-0 mt-2 sm:mt-5 "></div>

            <div
                className={`flex flex-wrap justify-center ${props.activeView === 'list'? 'flex-col' : ""} gap-2 sm:gap-6 mt-7 sm:mt-12`}>
                { props.children }
            </div>
        </>
    );
}

export default List;
