import React, {useEffect, useState} from "react";
import {useParams} from "react-router";
import {useDispatch, useSelector} from "react-redux";
import {resetAtlas, setAtlas, updateAtlasImage} from "../slices/atlasSlice";

import Page from "../components/Page";
import Header from "./_Header";
import Button from "../components/Button";
import ListSprites from "../components/List/ListSprites";
import Spinner from "../components/Spinner";
import useFetch from "../services/useFetch";
import consumer from "../channels/consumer";

const AtlasPage = () => {
    const atlasId = useParams().atlas_id
    const { atlas_id, title, atlas_img } = useSelector(state => state.atlas)
    const [loading, setLoading] = useState(false)
    const [loadingPercent,setLoadingPercent] = useState("0");

    const [choosenAlgo, setChoosenAlgo] = useState('inline')

    const dispatch = useDispatch();
    const {request} = useFetch()



    useEffect(() => {
        dispatch(resetAtlas())
        request(`/atlas/${atlasId}/info`, "GET")
            .then(data => {
                setChoosenAlgo(data.type)
                dispatch(setAtlas({
                    atlas_id: data.atlas_id,
                    title: data.title,
                    atlas_img: data.atlas_img
                }))
            })
            .catch(err => console.log("Error in AtlasPage: " + err.error + err.errors))
    }, []);

    const onAtlasUpdate = (type) => {
        setLoadingPercent('0')
        setLoading(true)
        setChoosenAlgo(type)
        const subscription = consumer.subscriptions.create(
            { channel: 'LoadingChannel', atlas_id: atlas_id },
            {
                connected: () => console.log('Connected to LoadingChannel'),
                disconnected: () => console.log('Disconnected from LoadingChannel'),
                received: (data) => {
                    setLoadingPercent(data.percent)
                }
            }
        )

        let requestBody = new FormData()
        requestBody.append("atlas_id", atlasId)
        requestBody.append("type", type)

        request("/atlas", "PUT", requestBody)
            .then(data => {
                dispatch(updateAtlasImage(data.atlas_img))
                setLoading(false)
            })
            .catch(err => console.log(err.error + err.errors))
    }

    const onTitleChange = (event) => {
        if (event.currentTarget.validity.valid) {
            let requestBody = new FormData()
            requestBody.append("atlas_id", atlasId)
            requestBody.append("new_title", event.target.value)
            request("/atlas", "PATCH", requestBody)
                .then(data => {
                    if (data.error_titleExists) {
                        event.target.style.borderColor = "#ff555d"
                    } else {
                        event.target.style.borderColor = "#e0b1cb"
                    }
                })
                .catch(err => console.log(err.error + err.errors))
        }

    }

    const [inputValue, setInputValue] = useState(title);

    useEffect(() => {
        setInputValue(title); // Сброс значения при смене страницы
    }, [title]);


    const title_width = " w-[" + title?.length*14 + "px]"

    return (
        <div className="font-unbounded min-h-screen bg-russian-violet">
            <Header />
            <Page title="texture atlas">
                <div className="-mt-7 sm:-mt-10 flex justify-end">
                    <Button type="violet">
                        <a href={atlas_img} download={title + '.png'}>
                            Download
                        </a>
                    </Button>
                </div>

                <div className="mt-6 mb-11">
                    <div className="absolute bg-pink h-1 w-screen left-0 mt-5 "></div>
                    <div className="w-min text-nowrap text-xl invisible absolute -top-96 -left-96 px-4"
                         id="title-helper">
                        {title}
                    </div>
                    <input
                        pattern="[A-Za-z0-9]*"
                        minLength={1}
                        maxLength={40}
                        className={`absolute bg-light-gray border-pink border-4 text-black text-sm sm:text-xl rounded-xl z-10 py-1.5 px-3 ${title_width} min-w-24`}
                        value={inputValue}
                        onChange={(e) => {
                            e.currentTarget.validity.valid
                            setInputValue(e.target.value)
                            document.getElementById('title-helper').innerText = e.currentTarget.value;
                            e.currentTarget.style.width = document.getElementById('title-helper').offsetWidth + "px";
                        }}
                        onBlur={onTitleChange}
                    />
                </div>
                <div id="atlas-img" className="bg-timberwolf rounded-xl border-pink border-dashed border-5 mt-24" >
                    <div className="m-2 sm:m-5 aspect-3/1"
                         style={{
                             backgroundImage: `url(\"/images/transparent.png\")`,
                             backgroundSize: "cover",
                         }}
                    >
                        { loading?
                            <Spinner loadingPercent={loadingPercent}/>
                            :
                            <img src={atlas_img} alt=""/>
                        }
                    </div>
                </div>
                <div className="flex flex-row justify-center gap-2 sm:gap-4 mt-4 sm:mt-8">
                    <Button type="violet"
                            className={choosenAlgo === 'inline' ? 'shadow-button-big' : '' }
                            onClick={() => onAtlasUpdate("inline")}
                    >
                        Update Inline
                    </Button>
                    <Button type="violet" className={choosenAlgo === 'bookshelf' ? 'shadow-button-big' : '' }
                            onClick={() => onAtlasUpdate("bookshelf")}
                    >
                        Update Bookshelf
                    </Button>
                    <Button type="violet" className={choosenAlgo === 'skyline' ? 'shadow-button-big' : '' }
                            onClick={() => onAtlasUpdate("skyline")}
                    >
                        Update Skyline
                    </Button>
                </div>

                <div className="mt-8">
                    <ListSprites title="IMAGES "/>
                </div>
            </Page>
        </div>
    );

}

export default AtlasPage;
