import React from "react";
import Button from "./Button";

const List = ({title, btnTitle, cardComponent, cardProps}) => {
    const activeFilter = 'list';
    const cards = null;

    return (
        <>
            <div className="flex flex-wrap justify-between align-bottom">
                <h2 className="text-3xl text-pink font-medium pt-2">
                    {title}
                    <span className="text-white">
                        list
                    </span>
                </h2>
                <div className="flex flex-row gap-5 align-middle">
                    <FilterButton type="list" active={activeFilter}/>
                    <FilterButton type="gallery" active={activeFilter}/>
                    <Button type="violet">Add</Button>
                </div>
            </div>
            <div className="absolute bg-pink h-1 w-screen left-0 mt-5 "></div>

            <div className="flex flex-wrap flex-row">
                {cards}
            </div>
        </>


    );
}

const FilterButton = (props) => {
    const style = props.type === props.active ? { filter: "drop-shadow(0px 0px 10px #E0B1CB)" } : null

    switch (props.type) {
        case 'list':
            return (
                <button type="button" >
                    <svg style={style} width="44" height="44" viewBox="0 0 44 44" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <path d="M9.375 13.125H35.625" stroke="#BE95C4" strokeWidth="5" strokeLinecap="round"/>
                        <path d="M9.375 23.3522H35.625" stroke="#BE95C4" strokeWidth="5" strokeLinecap="round"/>
                        <path d="M9.375 33.5795H35.625" stroke="#BE95C4" strokeWidth="5" strokeLinecap="round"/>
                    </svg>
                </button>
            );
        case 'gallery':
            return (
                <button type="button" >
                    <svg style={style} width="44" height="44" viewBox="0 0 44 44" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <rect x="7" y="7" width="11.5" height="11.5" rx="1" fill="#BE95C4" stroke="#BE95C4"
                              strokeWidth="2" strokeLinejoin="round"/>
                        <rect x="7" y="25.5" width="11.5" height="11.5" rx="1" fill="#BE95C4" stroke="#BE95C4"
                              strokeWidth="2" strokeLinejoin="round"/>
                        <rect x="25.5" y="25.5" width="11.5" height="11.5" rx="1" fill="#BE95C4" stroke="#BE95C4"
                              strokeWidth="2" strokeLinejoin="round"/>
                        <rect x="25.5" y="7" width="11.5" height="11.5" rx="1" fill="#BE95C4" stroke="#BE95C4"
                              strokeWidth="2" strokeLinejoin="round"/>
                    </svg>
                </button>
            );
        default:
            return null;
    }
}
export default List;
