import React from "react";

import Button from "../Button";
import ListViewButton from "./ListViewButton";

const List = (props) => {
    return (
        <>
            <div className="flex flex-wrap justify-between align-bottom">
                <h2 className="text-3xl text-pink font-medium pt-2">
                    {props.title}
                    <span className="text-white">
                        list
                    </span>
                </h2>
                <div className="flex flex-row gap-5 align-middle">
                    <ListViewButton type="list"
                                    active={props.activeView}
                                    onClick={() => props.setActiveView('list')}/>
                    <ListViewButton type="gallery"
                                    active={props.activeView}
                                    onClick={() => props.setActiveView('gallery')}/>
                    <Button type="violet" onClick={props.onAddElem}>
                        {props.btnTitle}
                    </Button>
                </div>
            </div>
            <div className="absolute bg-pink h-1 w-screen left-0 mt-5 "></div>

            {/* todo заменить flex на grid */}
            <div
                className={`
                    flex flex-wrap ${props.activeView === 'list'? "flex-col" : "flex-row"}
                    gap-6 mt-12
                `}>
                { props.children }
            </div>
        </>
    );
}

export default List;
