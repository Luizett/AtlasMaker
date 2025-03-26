import React from "react";

import Button from "../Button";
import FilterButton from "./FilterButton";

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
                    <FilterButton type="list"
                                  active={props.activeFilter}
                                  onClick={() => props.setActiveFilter('list')}/>
                    <FilterButton type="gallery"
                                  active={props.activeFilter}
                                  onClick={() => props.setActiveFilter('gallery')}/>
                    <Button type="violet" onClick={props.onAddElem}>
                        {props.btnTitle}
                    </Button>
                </div>
            </div>
            <div className="absolute bg-pink h-1 w-screen left-0 mt-5 "></div>

            <div className="flex flex-wrap flex-row">
                { props.children }
            </div>
        </>
    );
}

export default List;
