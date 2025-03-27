import React from "react";
import Button from "../../Button";
import {useSelector} from "react-redux";
const csrfToken = document.querySelector('meta[name="csrf-token"]').content;

const CardAtlas = ({activeView, atlasId, title, updatedAt, atlasImg, atlasSize}) => {

    const {token} = useSelector(state => state.session);

    const openAtlas = () => {
        // todo open atlas
    }

    const deleteAtlas = () => {
        let formData = new FormData();
        formData.append('atlas_id', atlasId);
        console.log("start delete atlas id " + atlasId)
        console.log(token)
        console.log(csrfToken)
        fetch('/atlas',{
            method: "DELETE",
            body: formData,
            headers: {
                'X-CSRF-Token': csrfToken,
                Authorization: `Bearer ${token}`
            }
        })
        .then(res => res.json())
        .then(data => {
            if (!data.message)
            { throw new Error(data.error + data.errors)}
            else
            { console.log(data)}
        })
        .catch(err => console.log("Error in deleteAtlas: " + err))
    }

    return activeView === 'gallery'?
        (
            <div className="flex flex-row bg-panel rounded-2xl p-5 text-white flex-auto max-w-[640px]"
                 onClick={openAtlas}>
                <div className="w-1/3">
                    <img className="aspect-square" src={atlasImg} width={242} height={242} alt=""/>
                </div>
                <div className="w-2/3 flex flex-col justify-between">
                    <div className="flex flex-row">
                        <div className="w-1/3 pl-4 flex flex-col gap-2">
                            <p>title:</p>
                            <p>update:</p>
                            <p>size:</p>
                        </div>
                        <div className="w-2/3 flex flex-col gap-2">
                            <p>{title}</p>
                            <p>{updatedAt}</p>
                            <p>{atlasSize}</p>
                        </div>
                    </div>
                    <div className="mx-auto">
                        <Button type="change" onClick={deleteAtlas}>delete atlas</Button>
                    </div>
                </div>
            </div>
        )
        :
        (
            <div className="flex flex-row rounded-2xl bg-panel justify-between px-8 py-3 text-white">
                <div className="flex gap-5">
                    <img className="aspect-square" width={50} height={50} src={atlasImg} alt=""/>
                    <p className="text-nowrap inline my-auto">{title}</p>
                </div>
                <div className="flex flex-row gap-4">
                    <p className="text-nowrap inline my-auto ">{atlasSize}</p>
                    <p className="text-nowrap inline my-auto ">{updatedAt}</p>
                    <button className="bg-cherry rounded-full aspect-square " onClick={deleteAtlas}>
                        <svg className="mx-auto" width="34" height="33" viewBox="0 0 34 33" fill="none" xmlns="http://www.w3.org/2000/svg">
                            <path fillRule="evenodd" clipRule="evenodd"
                                  d="M29.5005 8.27698H4.50049V12.385C5.22423 12.385 5.5861 12.385 5.87968 12.4775C6.50201 12.6737 6.98948 13.1612 7.1857 13.7835C7.27827 14.0771 7.27827 14.439 7.27827 15.1627V22.8169C7.27827 25.6453 7.27827 27.0595 8.15695 27.9382C9.03563 28.8169 10.4498 28.8169 13.2783 28.8169H20.7227C23.5511 28.8169 24.9654 28.8169 25.844 27.9382C26.7227 27.0595 26.7227 25.6453 26.7227 22.8169V15.1627C26.7227 14.439 26.7227 14.0771 26.8153 13.7835C27.0115 13.1612 27.499 12.6737 28.1213 12.4775C28.4149 12.385 28.7768 12.385 29.5005 12.385V8.27698ZM14.5283 15.1236C14.5283 14.5713 14.0806 14.1236 13.5283 14.1236C12.976 14.1236 12.5283 14.5713 12.5283 15.1236V21.9702C12.5283 22.5225 12.976 22.9702 13.5283 22.9702C14.0806 22.9702 14.5283 22.5225 14.5283 21.9702V15.1236ZM21.4727 15.1236C21.4727 14.5713 21.025 14.1236 20.4727 14.1236C19.9204 14.1236 19.4727 14.5713 19.4727 15.1236V21.9702C19.4727 22.5225 19.9204 22.9702 20.4727 22.9702C21.025 22.9702 21.4727 22.5225 21.4727 21.9702V15.1236Z"
                                  fill="#F5F5F5"/>
                            <path
                                d="M14.3169 4.67647C14.4752 4.53088 14.8239 4.40224 15.309 4.31049C15.7942 4.21874 16.3886 4.16901 17.0001 4.16901C17.6115 4.16901 18.2059 4.21874 18.6911 4.31049C19.1762 4.40224 19.5249 4.53088 19.6832 4.67647"
                                stroke="#F5F5F5" strokeWidth="2" strokeLinecap="round"/>
                        </svg>
                    </button>
                </div>
            </div>
        );
}

export default CardAtlas;