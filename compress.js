/* Browser-side display copies only; originals remain on the user's device. */
window.compressPortfolioImage=async function(file){
 const allowed=['image/jpeg','image/png','image/webp'];
 if(!allowed.includes(file.type))throw Error('Use JPG, PNG or WebP images. Convert HEIC/RAW first.');
 const maxBytes=900*1024,maxEdge=2400;
 const url=URL.createObjectURL(file);const image=new Image();
 try{image.src=url;await image.decode();if(!image.naturalWidth||!image.naturalHeight)throw Error('Invalid image.');
  if(file.size<=maxBytes&&Math.max(image.naturalWidth,image.naturalHeight)<=maxEdge)return file;
  const canvas=document.createElement('canvas');const ctx=canvas.getContext('2d');if(!ctx)throw Error('Image compression is unavailable in this browser.');
  let edge=Math.min(maxEdge,Math.max(image.naturalWidth,image.naturalHeight));let result;
  for(let round=0;round<8;round++){
   const scale=Math.min(1,edge/Math.max(image.naturalWidth,image.naturalHeight));
   canvas.width=Math.max(1,Math.round(image.naturalWidth*scale));canvas.height=Math.max(1,Math.round(image.naturalHeight*scale));
   ctx.clearRect(0,0,canvas.width,canvas.height);ctx.drawImage(image,0,0,canvas.width,canvas.height);
   for(const quality of [.88,.80,.72,.64]){result=await new Promise(resolve=>canvas.toBlob(resolve,'image/webp',quality));if(!result)throw Error('Could not encode this image.');if(result.size<=maxBytes){const ext=result.type==='image/webp'?'webp':'png';return new File([result],file.name.replace(/\.[^.]+$/,'')+'.'+ext,{type:result.type})}}
   edge=Math.round(edge*.78);
  }
  throw Error('This image could not be reduced below 900 KB. Please use a smaller image.');
 }finally{URL.revokeObjectURL(url)}
};
